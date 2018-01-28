# Snack Scan
Snack Scan is a unique and visually captivating application that will allow you to be more knowledgeable about the food that you’re planning on consuming. Worried about allergies, additives or preservatives? No worries! We’ve got you covered.

Instead of searching endlessly through all of those labels and noise, Snack Scan will show you right away what ingredients are in your food and how much of it is present. With stunning data visualization, you’ll be able to see how much sugar, fiber, fat, cholesterol and protein is in the food item you're holding in your hand. Want to know even more? Swipe left and the application will show you whether the amount of food you’ve eaten for that day has exceeded the limit approved by the FDA or by your nutritionist. Let us help you eliminate all the hassle of making sure that the product is safe and healthy for you!

![logo](/readme/logo.jpg)

How Snack Scan works on a high-level:
* User scans the UPC of a snack
* Behind the scene, snack scan makes an API call to FoodEssentials API
* We get that data as a JSON and present visually to the users

![flowchart](/readme/flowchart.jpg)

Snack Scan was created by Adithep Narula, Adisa Narula, and Ethan Lew.

# Detail view of each page

### Scan Page
This is the initial app view. User scans the UPC of the food product.

![scan-page](/readme/scan-page.jpg)

### Allergen Page

After the user scans the UPC of the food product, if the product exists in the API, the main view will blur out the video and overlay it with icons of allergens. Users can tap on icon to get the name of the allergen. User can either press the scanner icon on top of the page to re-scan or swipe left to continue to calorie page.

FoodLabels API - Everytime a barcode is scanned, the UPC code gets extracted from the product a GET response is made to the API and the API returns a JSON. This JSON is passed extracted and passed to the appropriate classes.

![allergen](/readme/allergen.jpg)

### Error Page

If the user scans the UPC of the food product and the product does not exists in the API, the main view will blur out the video and overlay it with an error picture. User can press the scan icon on top of the page to re-scan another product.


![error-page](/readme/error-page.jpg)

### Calorie Page

This page shows the calorie value in the scanned food product, the other scanned products’ calories that have been saved, and user’s daily remaining calories. User’s daily calorie intake is set at 2000 and as user scans and saves a product, the calorie value of the product is subtracted from 2000 to find the remaining calories. This provides an easy way for user to keep track of their intended calorie intake. User can swipe left to go to the last page.

![calorie](/readme/calorie.jpg)

### Grams Graph
This page shows the grams of different foods that the user has already consumed. The intake in grams are compared to the FDA recommended daily intake. Users can tap on the title on each column to get more information. On this page, user has the option to go back to rescan or save the product. To do either, press on the scan icon on top.

![grams](/readme/grams.jpg)

# Implementation Detail
One of the most interesting parts of this project was how we had to add UI objects programmatically. We did not use a storyboard because we had to add video view programatically and thus all of the user interfaces that come after this view were added programmatically.

## Core Plot Library
Core Plot is a plotting framework for Mac OS X and iOS. It provides 2D visualization of data, and is tightly integrated with Apple technologies like Core Animation, Core Data, and Cocoa Bindings. We utilized it to make our chart and graph.

#### Graphs
The central class of Core Plot is CPTGraph. In Core Plot, the term "graph" refers to the complete diagram, which includes axes, labels, a title, and one or more plots (e.g., histogram, line plot).CPTGraph is an abstract class from which all graph classes derive.

#### Plot Area
The plot area is that part of a graph where data is plotted. It is typically bordered by axes, and grid lines may also appear in the plot area. There is only one plot area for each graph, and it is represented by the class CPTPlotArea. The plot area is surrounded by a CPTPlotAreaFrame, which can be used to add a border to the area.

#### Plot Spaces
Plot spaces define the mapping between the coordinate space, in which a set of data exists, and the drawing space inside the plot area.

#### Plots
A particular representation of data in a graph is known as a "plot". For example, data could be shown as a line or scatter plot, with a symbol at each data point. The same data could be represented by a bar plot/histogram.

#### Axes
Axes describe the scale of the plotting coordinate space to the viewer. A basic graph will have just two axes, one for the horizontal direction (x) and one for the vertical direction (y), but this is not a constraint in Core Plot—you can add as many axes as you like. Axes can appear at the sides of the plot area, but also on top of it. Axes can have different scales, and can include major and/or minor ticks, as well as labels and a title.

#### Animation
A unique aspect of Core Plot is the integration of animation, which facilitates dynamic effects and interactivity. The Core Animation framework provides the mechanisms for positioning and transforming layers in time. In general you can access layers directly to apply animation. Be aware that transforming some layers, such as plots or the plot area, could invalidate the correspondence of data and axes

## CocoaPods
CocoaPods is a dependency manager that we used. It is available for Swift and Objective-C Cocoa projects. It has over eighteen thousand libraries and can help you scale your projects elegantly.

## FoodEssentials: Label API
Label API is a powerful API that provides various information about the food product that you’re about to consume. For this project, every time a barcode was scanned and the UPC code was extracted from the product, a GET Product Score request was made. The JSON response gives back the information that is used to present the information on different views of the application. The API provides us with information about the product’s additives, allergens, calories of the food and how many grams of each food group are present in the item. In addition, before the GET request can be made, a POST request is made to set the user profile that indicates which allergen, additives and ingredients the API should return.
