import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { User, VerificationLevel } from '../users/entities/user.entity';
import { sanitizeUser } from '../users/users.service';
import { RegisterDto, LoginDto, ResetPasswordDto } from './dto/credentials.dto';

interface OtpRecord {
  code: string;
  expiresAt: number;
}

/** Portfolio/demo login — always accepts this phone with this fixed code, no server restart needed to know it. */
const DEMO_PHONE = '+923000000000';
const DEMO_OTP = '1234';

@Injectable()
export class AuthService {
  // In-memory OTP / password-reset stores for development.
  // Replace with Redis (see 02-tech-architecture.md) before production.
  private otpStore = new Map<string, OtpRecord>();
  private resetStore = new Map<string, OtpRecord>();

  constructor(
    @InjectRepository(User) private usersRepo: Repository<User>,
    private jwt: JwtService,
  ) {}

  private sign(user: User) {
    return this.jwt.sign({ sub: user.id, phone: user.phone, role: user.role });
  }

  async requestOtp(phone: string): Promise<{ message: string; devCode?: string }> {
    const code = phone === DEMO_PHONE ? DEMO_OTP : Math.floor(1000 + Math.random() * 9000).toString();
    const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes
    this.otpStore.set(phone, { code, expiresAt });

    // TODO: integrate real SMS gateway (e.g. local Pakistani SMS provider) here.
    console.log(`[DEV OTP] ${phone} -> ${code}`);

    return {
      message: 'OTP sent',
      // devCode is only returned in non-production so you can test without SMS.
      devCode: process.env.NODE_ENV !== 'production' ? code : undefined,
    };
  }

  async verifyOtp(phone: string, code: string) {
    const record = this.otpStore.get(phone);
    if (!record || record.expiresAt < Date.now() || record.code !== code) {
      throw new UnauthorizedException('Invalid or expired OTP');
    }
    this.otpStore.delete(phone);

    let user = await this.usersRepo.findOne({ where: { phone } });
    if (!user) {
      user = this.usersRepo.create({
        phone,
        phoneVerified: true,
        verificationLevel: VerificationLevel.PHONE_VERIFIED,
      });
      await this.usersRepo.save(user);
    } else if (!user.phoneVerified) {
      user.phoneVerified = true;
      user.verificationLevel = VerificationLevel.PHONE_VERIFIED;
      await this.usersRepo.save(user);
    }

    return { accessToken: this.sign(user), user: sanitizeUser(user) };
  }

  async register(dto: RegisterDto) {
    const [existingEmail, existingPhone] = await Promise.all([
      this.usersRepo.findOne({ where: { email: dto.email } }),
      this.usersRepo.findOne({ where: { phone: dto.phone } }),
    ]);
    if (existingEmail) throw new ConflictException('An account with this email already exists');
    if (existingPhone) throw new ConflictException('An account with this phone number already exists');

    const passwordHash = await bcrypt.hash(dto.password, 10);
    const user = this.usersRepo.create({
      fullName: dto.fullName,
      email: dto.email,
      phone: dto.phone,
      passwordHash,
      verificationLevel: VerificationLevel.UNVERIFIED,
    });
    await this.usersRepo.save(user);

    return { accessToken: this.sign(user), user: sanitizeUser(user) };
  }

  async login(dto: LoginDto) {
    const user = await this.usersRepo.findOne({ where: { email: dto.email } });
    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('Invalid email or password');
    }
    const matches = await bcrypt.compare(dto.password, user.passwordHash);
    if (!matches) throw new UnauthorizedException('Invalid email or password');

    return { accessToken: this.sign(user), user: sanitizeUser(user) };
  }

  async forgotPassword(email: string): Promise<{ message: string; devCode?: string }> {
    const user = await this.usersRepo.findOne({ where: { email } });
    // Always respond the same way whether or not the account exists, to avoid leaking which emails are registered.
    if (user) {
      const code = Math.floor(1000 + Math.random() * 9000).toString();
      this.resetStore.set(email, { code, expiresAt: Date.now() + 15 * 60 * 1000 });
      console.log(`[DEV PASSWORD RESET] ${email} -> ${code}`);
    }
    return {
      message: 'If that email has an account, a reset code has been sent',
      devCode: process.env.NODE_ENV !== 'production' ? this.resetStore.get(email)?.code : undefined,
    };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const record = this.resetStore.get(dto.email);
    if (!record || record.expiresAt < Date.now() || record.code !== dto.code) {
      throw new UnauthorizedException('Invalid or expired reset code');
    }
    this.resetStore.delete(dto.email);

    const user = await this.usersRepo.findOne({ where: { email: dto.email } });
    if (!user) throw new UnauthorizedException('Invalid or expired reset code');

    user.passwordHash = await bcrypt.hash(dto.newPassword, 10);
    await this.usersRepo.save(user);

    return { accessToken: this.sign(user), user: sanitizeUser(user) };
  }
}
