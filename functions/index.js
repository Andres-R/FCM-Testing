// /**
//  * Import function triggers from their respective submodules:
//  *
//  * const {onCall} = require("firebase-functions/v2/https");
//  * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
//  *
//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
//  */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// // exports.helloWorld = onRequest((request, response) => {
// //   logger.info("Hello logs!", {structuredData: true});
// //   response.send("Hello from Firebase!");
// // });

const functions = require("firebase-functions");
const firebase = require("firebase-admin");
const fetch = require("node-fetch");

firebase.initializeApp();
const firestore = firebase.firestore();

// const iostoken = "cYkGwlkQnUGkrRJgIrVKuu:APA91bEUURiGjkiwwYM" +
// "09gomSgGRf89glV15ZoeiLrb1lxCMtzgRJp97rWNqgN5TSssJl1SjAB8E-WX" +
// "9Ejt7KgRcGwFMDYc2jWNv2kWwsfhw0Dpvg-LT0LtiVyFaNWy_p-LeDrfLwNc-";

const atoken = "dX8lTLADSuiAwFaEYXo_CU:APA91bE1rsaiSof7tcaU" +
"Mxymwt0bm74sQHzWXXN8FqapgoIMTmA7jK-Xj5sWOKiKO9y1uO79jJdgqTorei" +
"F7-6y5mrSP0HMgvYMEn51nRIA--INc0Pd0yDmD57hcQ-krS4YUat807gvN";

exports.checkAndSendNotifications = functions.pubsub
    .schedule("*/2 * * * *")
    .onRun(async (_) => {
      // get all notification settings
      const notifications = []; // --- important
      const notificationsCollection =
      await firestore.collection("notifications").get();
      notificationsCollection.forEach((doc) => {
        notifications.push(doc.data());
      });
      // get all unique symbols
      const symbolSet = new Set();
      for (let i = 0; i < notifications.length; i++) {
        const symbol = notifications[i]["currencySymbol"];
        symbolSet.add(symbol);
      }
      // make http requests to get performances of currencies
      const performances = {}; // --- important
      const symbols = [...symbolSet];
      const baseURL = "https://pro-api.coinmarketcap.com/v2";
      const category = "/cryptocurrency/quotes/latest";
      const parameter2 = "&CMC_PRO_API_KEY=";
      const key1 = "172d5f64-3e8e-42ed-8728-e3616d2a5ef9";
      for (let i = 0; i < symbols.length; i++) {
        const symbol = symbols[i];
        const parameter1 = "?symbol=" + symbol;
        const endpoint = baseURL + category + parameter1 + parameter2 + key1;
        try {
          const response = await fetch(endpoint);
          const text = await response.text();
          const json = JSON.parse(text);
          // --
          const data = json["data"];
          const currencySymbol = data[symbol];
          const listInfo = currencySymbol[0];
          const quote = listInfo["quote"];
          const usd = quote["USD"];
          const percentChange24h = usd["percent_change_24h"];
          // --
          performances[symbol] = percentChange24h;
        } catch (error) {
          console.log(error.response.body);
        }
      }
      // get all users
      const users = []; // --- important
      const usersCollection =
      await firestore.collection("users").get();
      usersCollection.forEach((doc) => {
        users.push(doc.data());
      });
      // store userIDs and tokens. Eg. {userID: token}
      const useridToToken = {}; // --- important
      for (let i = 0; i < users.length; i++) {
        useridToToken[users[i]["userID"]] = users[i]["token"];
      }
      // check notification settings and send notifications
      for (let i = 0; i < notifications.length; i++) {
        const setting = notifications[i];
        const userID = setting["userID"];
        const currencySymbol = setting["currencySymbol"];
        const currencyName = setting["currencyName"];
        const criteria = setting["criteria"];
        const criteriaPercent = parseFloat(setting["criteriaPercent"]);
        // --
        const currencyPerformance = parseFloat(performances[currencySymbol]);
        // --
        const notificationTitle = currencyName + " price action!";
        let body = null;
        if (criteria === "UP" && currencyPerformance > criteriaPercent) {
          body = currencyName + " is " + criteria +
          " " + currencyPerformance.toFixed(2) + "%";
        }
        if (criteria === "DOWN" && currencyPerformance < criteriaPercent) {
          body = currencyName + " is " + criteria +
          " " + currencyPerformance.toFixed(2) + "%";
        }
        // --
        if (body !== null) {
          const payloadMessage = {
            token: useridToToken[userID],
            notification: {
              title: notificationTitle,
              body: body,
            },
          };
          firebase.messaging().send(payloadMessage).then((response) => {
            console.log("Sucessfully sent message: ", response);
            return {success: true};
          }).catch((error) => {
            return {error: error.code};
          });
        }
        // v v v To be deleted for final server code v v v
        const payloadMessage = {
          token: atoken,
          notification: {
            title: "notificationTitle android",
            body: "body android",
          },
          apns: {
            payload: {
              aps: {
                contentAvailable: true,
              },
            },
          },
        };
        firebase.messaging().send(payloadMessage).then((response) => {
          console.log("Sucessfully sent message: ", response);
          return {success: true};
        }).catch((error) => {
          return {error: error.code};
        });
        // ^ ^ ^ ^
      }
      return null;
    });
// console.log(useridToToken);
// console.log(performances);
// console.log("<>ADA<>");
// console.log(performances["ADA"]);
// run command 'npx eslint . --fix' in functions
// directory if you have problems
