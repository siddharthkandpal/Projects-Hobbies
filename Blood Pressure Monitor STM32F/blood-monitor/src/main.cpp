#include "mbed.h"
#include "drivers/LCD_DISCO_F429ZI.h"
#define BACKGROUND 1
#define FOREGROUND 0
#define GRAPH_PADDING 5

I2C i2c(PC_9, PA_8);

// LCD Section
LCD_DISCO_F429ZI lcd;

//Buffer for LCD texts
char display_buf[3][60];
uint32_t graph_width=lcd.GetXSize()-2*GRAPH_PADDING;
uint32_t graph_height=graph_width;

// LCD setup function borrowed from Demo 8
void setup_background_layer(){
  lcd.SelectLayer(BACKGROUND);
  lcd.Clear(LCD_COLOR_BLACK);
  lcd.SetBackColor(LCD_COLOR_BLACK);
  lcd.SetTextColor(LCD_COLOR_GREEN);
  lcd.SetLayerVisible(BACKGROUND,ENABLE);
  lcd.SetTransparency(BACKGROUND,0x7Fu);
}

// LCD setup function borrowed from Demo 8
void setup_foreground_layer(){
    lcd.SelectLayer(FOREGROUND);
    lcd.Clear(LCD_COLOR_BLACK);
    lcd.SetBackColor(LCD_COLOR_BLACK);
    lcd.SetTextColor(LCD_COLOR_LIGHTGREEN);
}

// LCD setup function borrowed from Demo 8
void draw_graph_window(uint32_t horiz_tick_spacing){
  lcd.SelectLayer(BACKGROUND);
  
  lcd.DrawRect(GRAPH_PADDING,GRAPH_PADDING,graph_width,graph_width);
  for (uint32_t i = 0 ; i < graph_width;i+=horiz_tick_spacing){
    lcd.DrawVLine(GRAPH_PADDING+i,graph_height,GRAPH_PADDING);
  }
}

// LCD setup function borrowed from Demo 8
uint16_t mapPixelY(float inputY,float minVal, float maxVal, int32_t minPixelY, int32_t maxPixelY){
  const float mapped_pixel_y=(float)maxPixelY-(inputY)/(maxVal-minVal)*((float)maxPixelY-(float)minPixelY);
  return mapped_pixel_y;
}

void getDiastolic(float MAP, int mapIndex, int endIndex, float *slopeArray, int *bestSlopeIndex)
{
    float diaSlopeThreshold = 0.8 * MAP;
    float slopeDiff = 0;
    float minDiffSlope = (float)INT32_MAX;

    int i = 0;

    for (i = mapIndex + 1; i < endIndex; i++){
	if ((slopeArray[i] >= 0.0) && (slopeArray[i] < diaSlopeThreshold))
	{
	    slopeDiff = diaSlopeThreshold - slopeArray[i];
	    if (slopeDiff < minDiffSlope)
	    {
		minDiffSlope = slopeDiff;
		(*bestSlopeIndex) = i + 1;
	    }
	}
    }
}

//find the index of the sytolic value
void getSystolic(float MAP, int mapIndex, float *slopeArray, int *bestSlopeIndex)
{
    float sysSlopeThreshold = 0.5 * MAP;
    float slopeDiff = 0;
    float minDiffSlope = (float)INT32_MAX;

    int i = 0;

    for (i = 0; i < mapIndex; i++)
    {
	if ((slopeArray[i] >= 0.0) && (slopeArray[i] < sysSlopeThreshold))
	{
	    slopeDiff = sysSlopeThreshold - slopeArray[i];
	    if (slopeDiff < minDiffSlope)
	    {
		minDiffSlope = slopeDiff;
		(*bestSlopeIndex) = i + 1;
	    }
	}
    }
}

// Get the mean pressure based on the reading till now stored in the array
void getMeanPressure(float *pressureArray, int endIndex, float *timeArray, float *slopeArray, float *MAP, int *mapIndex)
{
	
    int i = 0;
    float pressureDiff = 0.0;
    float timeDiff = 0;
	
    for (i = 1; i < endIndex; i++)
    {
	pressureDiff = pressureArray[i] - pressureArray[i - 1];
	timeDiff = (timeArray[i] - timeArray[i - 1]);
	
	// Calculate Slope
	if (timeDiff != 0)
	{
		slopeArray[i - 1] = abs((pressureDiff / timeDiff));
	}
	// Calculate Max +ve Slope
	if (slopeArray[i - 1] > (*MAP))
	{
	    (*MAP) = slopeArray[i - 1];
	    (*mapIndex) = i;
	}
    }
}

//Find heart rate from the systolic and diastolic index values
void getHeartRate(int bestSSlopeIndex, int bestDSlopeIndex, float *slopeArray, float *timeArray, int *heartRate)
{
    int hr = 0;

    for (int i = bestSSlopeIndex; i <= bestDSlopeIndex; i++){
		if (slopeArray[i] >= 0.0)
	   		hr++;
    }
    (*heartRate) = ((hr / (timeArray[bestDSlopeIndex] - timeArray[bestSSlopeIndex])) * 60);
}

// Function to reset buffer memory and clear the line of LCD
void resetLCDBuffer()
{
	memset(display_buf[0], ' ', 60);
	memset(display_buf[1], ' ', 60);
	memset(display_buf[2], ' ', 60);
	lcd.DisplayStringAt(0, LINE(16), (uint8_t *)display_buf[0], LEFT_MODE);
	lcd.DisplayStringAt(0, LINE(17), (uint8_t *)display_buf[1], LEFT_MODE);
	lcd.DisplayStringAt(0, LINE(18), (uint8_t *)display_buf[2], LEFT_MODE);
}

//Print the buffers on the LCD
void printBufferToLCD()
{
	lcd.DisplayStringAt(0, LINE(16), (uint8_t *)display_buf[0], LEFT_MODE);
	lcd.DisplayStringAt(0, LINE(17), (uint8_t *)display_buf[1], LEFT_MODE);
	lcd.DisplayStringAt(0, LINE(18), (uint8_t *)display_buf[2], LEFT_MODE);
}

int main()
{
	thread_sleep_for(500);

	//Define Addresses and Sensor variables
    int sensorWriteAddr = (0x18 << 1);
    const char sensorOutReg[] = {0xAA, 0x00, 0x00};
    char sensorPresOut[4] ;
    float sensorOut = 0;
	sensorPresOut[0] = 0x00;

	//Define Pressure Variables
    int pressure = 0, pressureChange = 0, prevPressure = 0;
	char *pressureMessage = "";
	char optimal[50] = "Deflation correct";
    char fast[50] = "Deflation rate high";
    char slow[50] = "Deflation rate low";
	float pressureArray[150];
	float plotArray[300];
	float presSlopeArray[150] = {1.0};
	float meanPressure = 0.0;
	
	//Time and tick variables
    float timeArray[150];
	int counter = 0;
	int plotCounter = 0;
	Timer timerVar;

	//Define indexes for getting values from arrays
	int meanPresIndex = 0;
	int bestSysSlopeIndex = 0;
	int bestDiaSlopeIndex = 0;

	//HeartRate Variables
	int heartRate = 0;

	//Sensor limits as described in the sheet
	float oMin = 419430;
    float oMax = 3774873;
    float pMin = 0.0;
    float pMax = 300.0;

    bool increase = true, decrease = false;

	//Setup the LCD as done in Demo 8
	setup_background_layer();

  	setup_foreground_layer();

	draw_graph_window(10);
	int graphTick = 0;
	int time_ms = 0;
  
  	lcd.SelectLayer(FOREGROUND); 
	timerVar.start();
	while(1)
	{
		//Decide the state of user's attempt using the pressure value
		if (pressure > 151){
	    	increase = false;
		}

		if (!increase && pressure < 151){
	    	decrease = true;
		}
		if (pressure < 30 && decrease){
	    	break;
		}

		//Using the Method 2 in sensor, Find the output values and generate pressue values
		i2c.write(sensorWriteAddr, sensorOutReg, 3);
		i2c.read(sensorWriteAddr, &sensorPresOut[0], 4);
		thread_sleep_for(5);
		sensorOut = ((sensorPresOut[1] << 16) | (sensorPresOut[2] << 8) | (sensorPresOut[3]));
		pressure = (((sensorOut - oMin) * (pMax - pMin)) / (oMax - oMin)) + pMin;
		pressureChange =  prevPressure - pressure;

		//Change LCD message based on pressure change
		if (pressureChange >= 2 && pressureChange <= 4)
		{
			pressureMessage = optimal;
		}
		else if (pressureChange > 4.0)
		{
			pressureMessage = fast;
		}
		else
		{
			pressureMessage = slow;
		}

		//Plot the graph of the pressure 
		time_ms = timerVar.read_ms();
		plotCounter++;
		plotArray[plotCounter] = pressure;
		for(graphTick = 0; graphTick < plotCounter; graphTick++){
			const uint32_t target_x_coord=GRAPH_PADDING+(graphTick + 10);
			const uint32_t old_pixelY=mapPixelY(plotArray[graphTick],-2,200,GRAPH_PADDING,GRAPH_PADDING+graph_height);
			const uint32_t new_pixelY=mapPixelY(plotArray[graphTick],-2,200,GRAPH_PADDING,GRAPH_PADDING+graph_height);
			lcd.DrawPixel(target_x_coord,old_pixelY,LCD_COLOR_BLACK);
			lcd.DrawPixel(target_x_coord,new_pixelY,LCD_COLOR_RED); 
		}

		//Start the array storage when user begins decresing pressure
		if (decrease)
		{
			//If the process takes more than 75 sec (150*.5) abandon the run as values likely to be wrong
			if(counter == 150)
			{
				resetLCDBuffer();
				snprintf(display_buf[0],60,"Abandoning reading ");
				snprintf(display_buf[1],60,"time limit is 1.5 min ");
				snprintf(display_buf[2],60,"Abandoning reading ");
				printBufferToLCD();
				break;
			}
			//Print out cue to the user to help with pressure process
			resetLCDBuffer();
			snprintf(display_buf[0],60,"Pressure is %d",(int)pressure);
			snprintf(display_buf[1],60, "Changed %d", (int)pressureChange);
			snprintf(display_buf[2],60, pressureMessage);
			printBufferToLCD();

			pressureArray[counter] = pressure;
			timeArray[counter] = time_ms / 1000;
			counter++;
		}
		else
		{
			//Print out cue to the user to not exceed pressure too much
			if(pressure > 151){
				resetLCDBuffer();
				snprintf(display_buf[0],60,"Pressure is %d",(int)pressure);
				snprintf(display_buf[1],60, "Decrease pressure");
				printBufferToLCD();
			}
			else{
				//Print out cue to the user to reach the 150 threshold
				resetLCDBuffer();
				snprintf(display_buf[0],60,"Pressure is %d",(int)pressure);
				snprintf(display_buf[1],60, "Increase till 150");
				printBufferToLCD();
			}
		}
		//Save the current pressure value as the previous one
		prevPressure = pressure;
		thread_sleep_for(1000);	 //Take readings every 500ms
	}

	//Get The values from the data recieved and print them onto the buffer
	timerVar.stop();
    getMeanPressure(pressureArray, counter, timeArray, presSlopeArray, &meanPressure, &meanPresIndex);
    getSystolic(meanPressure, meanPresIndex, presSlopeArray, &bestSysSlopeIndex);
    getDiastolic(meanPressure, meanPresIndex, counter, presSlopeArray, &bestDiaSlopeIndex);
    getHeartRate(bestSysSlopeIndex, bestDiaSlopeIndex, presSlopeArray, timeArray, &heartRate);
	resetLCDBuffer();
	snprintf(display_buf[0],60,"Systolic %d",(int)pressureArray[bestSysSlopeIndex]);
	snprintf(display_buf[1],60, "Diastolic %d", (int)pressureArray[bestDiaSlopeIndex]);
	snprintf(display_buf[2],60, "Heart Rate %d", heartRate);
	printBufferToLCD();
}