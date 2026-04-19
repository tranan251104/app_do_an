const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {FieldValue} = require("firebase-admin/firestore");
const nodemailer = require("nodemailer");
const express = require("express");

admin.initializeApp();
const db = admin.firestore();
const app = express();

// Middleware parse JSON thủ công
app.use(express.json());

// Gmail hệ thống
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "tranan251104@gmail.com",
    pass: "dghjshfwxmvwtydo", // App password Gmail
  },
});

// API gửi OTP
app.post("/sendOtp", async (req, res) => {
  try {
    console.log("📩 Raw body:", req.body);

    const email = req.body.email;
    console.log("📩 Sending OTP to:", email);

    if (!email) {
      return res.status(400).send("Email is required");
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    // Lưu OTP vào Firestore
    await db.collection("otps").doc(email).set({
      otp: otp,
      createdAt: FieldValue.serverTimestamp(), // ✅ dùng FieldValue chứ không phải admin.firestore.FieldValue
    });

    // Gửi email
    const mailOptions = {
      from: "tranan251104@gmail.com",
      to: email,
      subject: "Xác nhận giao dịch",
      text: `Mã OTP của bạn là: ${otp} (có hiệu lực trong 5 phút)`,
    };

    await transporter.sendMail(mailOptions);
    console.log("✅ OTP sent to:", email, "Code:", otp);
    res.status(200).send("OTP sent to " + email);

  } catch (err) {
    console.error("❌ Error in sendOtp:", err);   // log chi tiết
    res.status(500).send("Server error: " + err.message); // trả error cụ thể
  }
});

// API xác minh OTP
app.post("/verifyOtp", async (req, res) => {
  try {
    console.log("📩 Verify body:", req.body);
    const email = req.body.email;
    const otpInput = req.body.otp;

    if (!email || !otpInput) {
      return res.status(400).send("Email and OTP are required");
    }
    const doc = await db.collection("otps").doc(email).get();
    if (!doc.exists) return res.status(400).send("OTP not found");

    const { otp } = doc.data();
    if (otp === otpInput) {
      await db.collection("otps").doc(email).delete();
      console.log("✅ OTP verified for:", email);
      return res.status(200).send("OK");
    } else {
      console.log("❌ Wrong OTP for:", email, "Input:", otpInput, "Expected:", otp);
      return res.status(400).send("Sai OTP");
    }
  } catch (err) {
    console.error("❌ Error in verifyOtp:", err);
    res.status(500).send("Server error: " + err.message);
  }
});

// API đặt lại mật khẩu
app.post("/resetPassword", async (req, res) => {
  try {
    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
      return res.status(400).send("Email and new password are required");
    }

    // Tìm user theo email
    const user = await admin.auth().getUserByEmail(email);

    // Cập nhật mật khẩu mới
    await admin.auth().updateUser(user.uid, {
      password: newPassword,
    });

    console.log("✅ Password reset for:", email);
    res.status(200).send("Password updated successfully");
  } catch (err) {
    console.error("❌ Error in resetPassword:", err);
    res.status(500).send("Server error: " + err.message);
  }
});

// Export API
exports.api = functions.https.onRequest(app);

