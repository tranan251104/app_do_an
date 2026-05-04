const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const {FieldValue} = require("firebase-admin/firestore");
const nodemailer = require("nodemailer");

admin.initializeApp();
const db = admin.firestore();

// CẤU HÌNH GỬI MAIL
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "tranan251104@gmail.com",
    pass: "bljupjxiklhwxoka", // Mật khẩu ứng dụng của bạn
  },
});

exports.sendOtp = onRequest({ cors: true }, async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).send("Thiếu email");

  const otp = Math.floor(100000 + Math.random() * 900000).toString();

  try {
    // Lưu OTP vào Firestore
    await db.collection("otps").doc(email).set({
      otp: otp,
      createdAt: FieldValue.serverTimestamp(), // Đã sửa cách gọi FieldValue
    });

    // Gửi mail thật
    await transporter.sendMail({
      from: '"ANPAY Support" <tranan251104@gmail.com>',
      to: email,
      subject: "Mã xác thực OTP của bạn",
      text: `Mã OTP của bạn là: ${otp}. Mã có hiệu lực trong 5 phút.`,
    });

    res.status(200).send({ message: "Đã gửi OTP" });
  } catch (error) {
    console.error("Lỗi gửi mail:", error);
    res.status(500).send("Lỗi hệ thống: " + error.message);
  }
});

exports.verifyOtp = onRequest({ cors: true }, async (req, res) => {
  const { email, otp } = req.body;
  try {
    const doc = await db.collection("otps").doc(email).get();
    if (doc.exists && doc.data().otp === otp) {
      await db.collection("otps").doc(email).delete();
      res.status(200).send({ success: true });
    } else {
      res.status(400).send({ success: false, message: "Mã không đúng hoặc hết hạn" });
    }
  } catch (error) {
    res.status(500).send("Lỗi xác thực");
  }
});
