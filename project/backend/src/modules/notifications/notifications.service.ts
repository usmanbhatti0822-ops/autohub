import { Injectable, Logger } from '@nestjs/common';

/**
 * NOTE ON PUSH NOTIFICATIONS
 * --------------------------
 * Wiring real Firebase Cloud Messaging needs a Firebase service-account
 * JSON (from your Firebase project settings) that only you can generate.
 * Once you have it:
 *   1. `npm install firebase-admin`
 *   2. Initialize admin.initializeApp({ credential: admin.credential.cert(serviceAccount) })
 *   3. Replace the console.log below with admin.messaging().send({...})
 * Device tokens should be stored on the User entity (add a `fcmToken`
 * column) and updated by the mobile app after login.
 */
@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  async sendPush(userId: string, title: string, body: string) {
    // TODO: replace with real FCM call once service-account credentials exist.
    this.logger.log(`[DEV PUSH] -> user ${userId}: ${title} — ${body}`);
    return { sent: true, dev: true };
  }

  async notifyBookingUpdate(userId: string, status: string) {
    return this.sendPush(userId, 'Booking update', `Your booking is now ${status}`);
  }

  async notifyNewMessage(userId: string, fromName: string) {
    return this.sendPush(userId, 'New message', `${fromName} sent you a message`);
  }

  async notifyNewOffer(userId: string, amount: number) {
    return this.sendPush(userId, 'New offer', `You received an offer of PKR ${amount}`);
  }
}
