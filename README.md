# Sunrise-Moonrise-Weather
Sunrise-Moonrise and Weather is an IOS weather app written in Swift 2 done as a part of Udacity’s iOS Developer Nanodegree. This is an open-ended project, designed to give us an opportunity to build a new app from ground up. 

Main objectives of this project:
  -	Combine the UIKit components to design sophisticated user interfaces.
  -	Downloading JSON data from networked resources 
  - Persisting state on a device using Core Data and NSUserDefaults 

The initial launch of the app requires the user to allow location services to track the current location of the user. The app fetches the current location and display the weather data in different tabs.

The view of the app has three tabs:
	- 'Today' shows the current day’s forecast 
	  '7 day' shows the next 7 days forecast
     Sun/Moon' shows the rise/set times of sun and moon and also the phase name and phase percentage of the moon. The user can also change dates and view the information for the past or future dates.`

There is a menu button on the top right corner. This will take the user to a view where the user can add new locations, remove previously added locations and change from C to F or vice versa. After entering the location, once the user clicks on the location name, the initial view comes up with the selected location’s forecast. Also, there is a button for viewing the current location’s forecast back again. 

The app uses two APIs for the data:
  -	AerisWeather API provides the data for the sun,moon and weather forecast.
	-	GoogleTimeZoneAPI provides the time zone information for the location selected and displays the sun/moon times accordingly.
