const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const sendNotification = (newValue, collectionName, userToken) => {
  const payload = {
    notification: {
      title: `${collectionName}에 새로운 데이터가 추가되었습니다!`,
      body: `데이터 내용: ${newValue.title}`,
    },
  };

  return admin
    .messaging()
    .sendToDevice(userToken, payload)
    .then((response) => {
      console.log("Successfully sent message:", response);
      return null;
    })
    .catch((error) => {
      console.log("Error sending message:", error);
    });
};

const checkAndSendNotification = async (newValue, collectionName) => {
  try {
    const usersSnapshot = await admin.firestore().collection("users").get();
    usersSnapshot.forEach((userDoc) => {
      const userData = userDoc.data();
      const keywords = userData.keyword ? userData.keyword.split(",") : [];

      keywords.forEach((keyword) => {
        if (newValue.title.includes(keyword)) {
          const userToken = userData.fcmToken; // 사용자의 FCM 토큰
          sendNotification(newValue, collectionName, userToken);
        }
      });
    });
  } catch (error) {
    console.log("Error checking keywords and sending notifications:", error);
  }
};

exports.sendNotificationOnDormNoticesDorm = functions.firestore
  .document("dormNotices_기숙사공지/{docId}")
  .onCreate((snapshot, context) => {
    const newValue = snapshot.data();
    return checkAndSendNotification(newValue, "기숙사공지");
  });

exports.sendNotificationOnDormNoticesEnterExit = functions.firestore
  .document("dormNotices_입퇴사공지/{docId}")
  .onCreate((snapshot, context) => {
    const newValue = snapshot.data();
    return checkAndSendNotification(newValue, "입퇴사공지");
  });

exports.sendNotificationOnGeneralNotices = functions.firestore
  .document("notices_일반공지/{docId}")
  .onCreate((snapshot, context) => {
    const newValue = snapshot.data();
    return checkAndSendNotification(newValue, "일반공지");
  });

exports.sendNotificationOnAcademicNotices = functions.firestore
  .document("notices_학사공지/{docId}")
  .onCreate((snapshot, context) => {
    const newValue = snapshot.data();
    return checkAndSendNotification(newValue, "학사공지");
  });

exports.sendNotificationOnBidNotices = functions.firestore
  .document("notices_입찰공지/{docId}")
  .onCreate((snapshot, context) => {
    const newValue = snapshot.data();
    return checkAndSendNotification(newValue, "입찰공지");
  });

exports.sendNotificationOnSafetyNotices = functions.firestore
  .document("notices_대학안전공지/{docId}")
  .onCreate((snapshot, context) => {
    const newValue = snapshot.data();
    return checkAndSendNotification(newValue, "대학안전공지");
  });

exports.sendNotificationOnScholarshipNotices = functions.firestore
  .document("notices_장학학자금공지/{docId}")
  .onCreate((snapshot, context) => {
    const newValue = snapshot.data();
    return checkAndSendNotification(newValue, "장학학자금공지");
  });

exports.sendNotificationOnCareerNotices = functions.firestore
  .document("notices_진로취업창업공지/{docId}")
  .onCreate((snapshot, context) => {
    const newValue = snapshot.data();
    return checkAndSendNotification(newValue, "진로취업창업공지");
  });

exports.sendNotificationOnStudentActivityNotices = functions.firestore
  .document("notices_학생활동공지/{docId}")
  .onCreate((snapshot, context) => {
    const newValue = snapshot.data();
    return checkAndSendNotification(newValue, "학생활동공지");
  });

exports.sendNotificationOnRegulationNotices = functions.firestore
  .document("notices_학칙개정사전공고/{docId}")
  .onCreate((snapshot, context) => {
    const newValue = snapshot.data();
    return checkAndSendNotification(newValue, "학칙개정사전공고");
  });

exports.sendNotificationOnEventNotices = functions.firestore
  .document("notices_행사공지/{docId}")
  .onCreate((snapshot, context) => {
    const newValue = snapshot.data();
    return checkAndSendNotification(newValue, "행사공지");
  });

