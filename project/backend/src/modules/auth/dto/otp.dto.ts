import { IsString, Matches, Length } from 'class-validator';

export class RequestOtpDto {
  @IsString()
  @Matches(/^\+92[0-9]{10}$/, {
    message: 'Phone must be in format +923XXXXXXXXX',
  })
  phone: string;
}

export class VerifyOtpDto {
  @IsString()
  @Matches(/^\+92[0-9]{10}$/)
  phone: string;

  @IsString()
  @Length(4, 6)
  code: string;
}
