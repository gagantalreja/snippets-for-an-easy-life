/*

The following script was created to fill in the consolidated work sheet we
maintain at Schrodinger. The script fetches data from a weekly timesheet (manually updated)
and fills in the actual time and estimted time taken to complete a given ticket. The closure
date of the ticket is fetched using JIRA api.

*/

function getTicketClosureDate(ticketId) {
  var jiraDomain = "https://organisation.atlassian.net"; // Replace with your Jira domain
  var email = ""; // Jira login email
  var apiToken = ""; // Jira API token
  var url = jiraDomain + "/rest/api/3/issue/" + ticketId + "?expand=changelog";

  var headers = {
    "Authorization": "Basic " + Utilities.base64Encode(email + ":" + apiToken),
    "Accept": "application/json"
  };

  var options = {
    "method": "GET",
    "headers": headers,
    "muteHttpExceptions": true
  };

  var response = UrlFetchApp.fetch(url, options);
  var jsonResponse = JSON.parse(response.getContentText());

  var changelog = jsonResponse.changelog.histories;
  
  for (var i = 0; i < changelog.length; i++) {
    var history = changelog[i];
    for (var j = 0; j < history.items.length; j++) {
      var item = history.items[j];
      if (item.field == "status" && item.toString == "Closed") {
        return history.created.split("T")[0]; // Returns date when status changed to "Closed"
      }
    }
  }

  Logger.log("No closure date found for ticket " + ticketId);
  return "na";
}



function onEdit(e) {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sourceSheet = ss.getSheetByName("Weekly"); // Source sheet
  var targetSheet = ss.getSheetByName("Consolidated"); // Target sheet
  
  if (!targetSheet) {
    targetSheet = ss.insertSheet("Consolidated");
    targetSheet.appendRow(["Jira", "Task Name", "Estimate", "Actual", "Completed"]); // Headers
  }

  var range = targetSheet.getRange("A3:A" + targetSheet.getLastRow()); // Get all non-empty rows in column A
  var valuesToRemove = range.getValues().flat(); // Convert 2D array to 1D list

  var selectedColumns = [1,2,5,6]
  var dataRange = sourceSheet.getDataRange();

  var data = dataRange.getValues();
  data = data.map(row => selectedColumns.map(index => row[index]));

  var textColors = dataRange.getFontColors();
  textColors = textColors.map(row => selectedColumns.map(index => row[index]));
  textColors = textColors.map(row => row[0])


  var indexesToRemove = data
    .map((item, index) => (valuesToRemove.includes(item[0]) || item.includes("Estimate") || item.includes("Jira") || item[0].includes("Week") || item.every(it => it === "") || textColors[index] !== "#6aa84f") ? index : -1)
    .filter(index => index !== -1);

  data = data.filter((_, index) => !indexesToRemove.includes(index));
  
  var completed_tickets = [];
  for (var i = 0; i < data.length; i++) {
    var completionDate = getTicketClosureDate(data[i][0])
    data[i].push(completionDate)
    completed_tickets.push(data[i])

    console.log(data[i]);
  }

  if (completed_tickets.length > 0) {
    targetSheet.getRange(targetSheet.getLastRow() + 1, 1, completed_tickets.length, completed_tickets[0].length)
               .setValues(completed_tickets);
  }
}
