# Snack Scan
Snack Scan is an IOS app that provides a way for users to keep track of nutritional information about food/snack they wish to purchase by scanning the product’s UPC code. Nutritional values include allergens, calories, and different food groups like fats, carbohydrates, sodium.

How Snack Scan works on a high-level:
* User scans the UPC of a snack
* Behind the scene, snack scan makes an API call to FoodEssentials API
* We get that data as a JSON and present visually to the users

## Detail view of each page and its mechanics

### Scan Page
This is the initial app view. User scans the UPC of the food product.

### Allergen Page

After the user scans the UPC of the food product, if the product exists in the API, the main view will blur out the video and overlay it with icons of allergens. Users can tap on icon to get the name of the allergen. User can either press the scanner icon on top of the page to re-scan or swipe left to continue to calorie page.

FoodLabels API - Everytime a barcode is scanned, the UPC code gets extracted from the product a GET response is made to the API and the API returns a JSON. This JSON is passed extracted and passed to the appropriate classes.

### Error Page

If the user scans the UPC of the food product and the product does not exists in the API, the main view will blur out the video and overlay it with an error picture. User can press the scan icon on top of the page to re-scan another product.

### Calorie Page

This page shows the calorie value in the scanned food product, the other scanned products’ calories that have been saved, and user’s daily remaining calories. User’s daily calorie intake is set at 2000 and as user scans and saves a product, the calorie value of the product is subtracted from 2000 to find the remaining calories. This provides an easy way for user to keep track of their intended calorie intake. User can swipe left to go to the last page.

### Grams Graph

This page shows the grams of different foods that the user has already consumed. The intake in grams are compared to the FDA recommended daily intake. Users can tap on the title on each column to get more information. On this page, user has the option to go back to rescan or save the product. To do either, press on the scan icon on top.

## Implementation Detail

One of the most interesting parts of this project was how we had to add UI objects programmatically. We did not use a storyboard because we had to add video view programatically and thus all of the user interfaces that come after this view were added programmatically.

### Core Plot Library
Core Plot is a plotting framework for Mac OS X and iOS. It provides 2D visualization of data, which we utilized in our project.

#### Graphs
The central class of Core Plot is CPTGraph. In Core Plot, the term "graph" refers to the complete diagram, which includes axes, labels, a title, and one or more plots (e.g., histogram, line plot).CPTGraph is an abstract class from which all graph classes derive.

#### Animation
A unique aspect of Core Plot is the integration of animation, which facilitates dynamic effects and interactivity. The Core Animation framework provides the mechanisms for positioning and transforming layers in time. In general you can access layers directly to apply animation. Be aware that transforming some layers, such as plots or the plot area, could invalidate the correspondence of data and axes
