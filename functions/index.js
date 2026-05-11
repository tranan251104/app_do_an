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

// 1. Hàm gửi OTP
exports.sendOtp = onRequest({ cors: true }, async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).send("Thiếu email");
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  try {
    await db.collection("otps").doc(email).set({
      otp: otp,
      createdAt: FieldValue.serverTimestamp(),
    });
    await transporter.sendMail({
      from: '"ANPAY Support" <tranan251104@gmail.com>',
      to: email,
      subject: "Mã xác thực OTP của bạn",
      text: `Mã OTP của bạn là: ${otp}. Mã có hiệu lực trong 5 phút.`,
    });
    res.status(200).send({ message: "Đã gửi OTP" });
  } catch (error) {
    res.status(500).send("Lỗi hệ thống: " + error.message);
  }
});

// 2. Hàm gửi Email thông báo biến động số dư
exports.sendTransactionEmail = onRequest({ cors: true }, async (req, res) => {
  const { email, type, amount, balance, note, time } = req.body;

  if (!email) return res.status(400).send("Thiếu email");

  const formattedAmount = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
  const formattedBalance = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(balance);

  const mailOptions = {
    from: '"ANPAY - Biến động số dư" <tranan251104@gmail.com>',
    to: email,
    subject: `[ANPAY] Biến động số dư -${type === 'transfer' ? '' : '+'}${formattedAmount}`,
    html: `
      <div style="font-family: Arial, sans-serif; border: 1px solid #ddd; padding: 20px; border-radius: 10px; max-width: 500px;">
        <h2 style="color: #d32f2f; text-align: center;">ANPAY</h2>
        <p>Kính chào quý khách,</p>
        <p>Tài khoản của quý khách vừa có biến động số dư:</p>
        <table style="width: 100%;">
          <tr><td><b>Loại giao dịch:</b></td><td>${type === 'transfer' ? 'Chuyển tiền' : 'Nhận tiền/Nạp tiền'}</td></tr>
          <tr><td><b>Số tiền:</b></td><td style="color: ${type === 'transfer' ? 'red' : 'green'};"><b>${type === 'transfer' ? '-' : '+'}${formattedAmount}</b></td></tr>
          <tr><td><b>Số dư cuối:</b></td><td><b>${formattedBalance}</b></td></tr>
          <tr><td><b>Nội dung:</b></td><td>${note || 'N/A'}</td></tr>
          <tr><td><b>Thời gian:</b></td><td>${time}</td></tr>
        </table>
        <p style="margin-top: 20px; font-size: 12px; color: #888; text-align: center;">Đây là email tự động, vui lòng không trả lời.</p>
      </div>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    res.status(200).send({ message: "Đã gửi email thông báo" });
  } catch (error) {
    res.status(500).send("Lỗi gửi email: " + error.message);
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
