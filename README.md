### Exchange Rates Mobile App

Implement a small exchange rate application which does the following:
- Uses exchange rate data from this web service: https://exchangeratesapi.io
- Shows the latest exchange rates in a listview. USD should be used as base currency.

Each list item of the listview should have 2 rows: the currency name in the first row and the latest exchange rate (with two decimal precision) in the second row.

The latest exchange rate data can be requested like this: https://api.exchangeratesapi.io/latest?base=USD 

Once the currency data is loaded from the web service, save it in a local database too. Also, save the timestamp of the last request somewhere.
Next time user opens the app you should check whether 10 minutes elapsed since the last request:
- If yes, you should load new data from web service.
- If no, you should load previously saved data from the local database.
- If user clicks on a list item a new screen should be opened which shows the exchange rate graph/chart of the selected currency for the last 7 days.

Here it is not necessary to save anything in the local database, you should request every time the currency data for the last 7 days.
Example request for getting currency history in a given period between USD and CAD:
https://api.exchangeratesapi.io/history?start_at=2019-11-27&end_at=2019-12-03&base=USD&symbols=CAD

You can use any third party library for drawing currency graph/chart. If web service does not return data for the last 7 days, please show a warning popup with the following message: No exchange rate data is available for the selected currency.