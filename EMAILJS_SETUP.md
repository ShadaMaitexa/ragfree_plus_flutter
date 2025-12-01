# EmailJS Setup Guide

This application uses EmailJS to send email notifications for various events. Follow these steps to configure EmailJS:

## Step 1: Create an EmailJS Account

1. Go to [https://www.emailjs.com/](https://www.emailjs.com/)
2. Sign up for a free account (free tier includes 200 emails/month)

## Step 2: Add Email Service

1. In your EmailJS dashboard, go to **Email Services**
2. Click **Add New Service**
3. Choose your email provider (Gmail, Outlook, etc.)
4. Follow the setup instructions for your provider
5. Note your **Service ID** (e.g., `service_xxxxx`)

## Step 3: Create Email Template

1. Go to **Email Templates** in your EmailJS dashboard
2. Click **Create New Template**
3. Use the following template variables:
   - `{{to_email}}` - Recipient email address
   - `{{to_name}}` - Recipient name
   - `{{subject}}` - Email subject
   - `{{message}}` - Email message body
   - `{{html_message}}` - HTML formatted message (optional)

4. Example template:
   ```
   To: {{to_email}}
   Subject: {{subject}}
   
   Dear {{to_name}},
   
   {{message}}
   
   Best regards,
   RAG FREE+ Team
   ```

5. Note your **Template ID** (e.g., `template_xxxxx`)

## Step 4: Get Your Public Key

1. Go to **Account** → **General** in your EmailJS dashboard
2. Find your **Public Key** (e.g., `xxxxxxxxxxxxx`)

## Step 5: Configure the Application

1. Open `lib/services/emailjs_service.dart`
2. Replace the placeholder values:
   ```dart
   static const String _publicKey = 'YOUR_PUBLIC_KEY'; // Replace with your EmailJS public key
   static const String _serviceId = 'YOUR_SERVICE_ID'; // Replace with your EmailJS service ID
   static const String _templateId = 'YOUR_TEMPLATE_ID'; // Replace with your EmailJS template ID
   ```

3. Example:
   ```dart
   static const String _publicKey = 'abc123xyz789';
   static const String _serviceId = 'service_gmail';
   static const String _templateId = 'template_notifications';
   ```

## Step 6: Test Email Sending

1. Run your application
2. Register a new user or submit a complaint
3. Check the recipient's email inbox
4. Check the EmailJS dashboard for delivery status

## Email Notifications Sent

The application sends emails for:

1. **User Registration** - When a user registers (pending approval)
2. **Account Approval** - When admin approves a user account
3. **Complaint Submission** - When a student submits a complaint
4. **Complaint Status Update** - When complaint status changes
5. **Complaint Assignment** - When a complaint is assigned to a counselor
6. **Emergency Alerts** - When admin/police sends emergency alerts
7. **General Notifications** - For other important notifications

## Troubleshooting

### Emails Not Sending

1. **Check Configuration**: Ensure all three values (public key, service ID, template ID) are correctly set
2. **Check EmailJS Dashboard**: Look for error messages in the EmailJS dashboard
3. **Check Console Logs**: The app logs errors if email sending fails
4. **Verify Service Connection**: In EmailJS dashboard, test your email service connection
5. **Check Rate Limits**: Free tier has 200 emails/month limit

### Common Errors

- **"Configuration not set"**: One or more EmailJS credentials are still set to placeholder values
- **"EmailJS send failed"**: Check your EmailJS dashboard for detailed error messages
- **"Service ID not found"**: Verify your service ID in EmailJS dashboard

## Security Note

⚠️ **Important**: The public key is safe to expose in client-side code. However, for production apps, consider:
- Using environment variables or a configuration file
- Implementing server-side email sending for sensitive operations
- Using EmailJS's private keys for server-side operations

## Free Tier Limits

- 200 emails per month
- Basic email templates
- Standard support

For higher limits, upgrade to a paid plan on EmailJS.


