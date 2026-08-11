import {
  BadRequestException,
  Controller,
  Post,
  Req,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import { randomUUID } from 'crypto';
import type { Request } from 'express';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

const ALLOWED_MIME = new Set(['image/jpeg', 'image/png', 'image/webp', 'image/gif']);

/**
 * NOTE ON STORAGE
 * ----------------
 * Files are saved to a local `uploads/` folder and served statically (see
 * main.ts). This keeps the demo fully self-contained with no cloud
 * credentials required. To move to S3-compatible storage: replace the
 * `diskStorage` below with a multer-s3 (or manual PutObject) storage
 * engine, and return the resulting bucket URLs instead of local paths —
 * everything downstream (listings/rentals `photoUrls`) already just
 * stores plain URL strings, so no other code needs to change.
 */
@Controller('uploads')
@UseGuards(JwtAuthGuard)
export class UploadsController {
  @Post()
  @UseInterceptors(
    FilesInterceptor('files', 6, {
      storage: diskStorage({
        destination: join(process.cwd(), 'uploads'),
        filename: (_req, file, cb) => {
          cb(null, `${randomUUID()}${extname(file.originalname).toLowerCase()}`);
        },
      }),
      limits: { fileSize: 8 * 1024 * 1024 },
      fileFilter: (_req, file, cb) => {
        if (!ALLOWED_MIME.has(file.mimetype)) {
          cb(new BadRequestException('Only JPG, PNG, WEBP or GIF images are allowed'), false);
          return;
        }
        cb(null, true);
      },
    }),
  )
  upload(@UploadedFiles() files: Array<Express.Multer.File>, @Req() req: Request) {
    if (!files?.length) throw new BadRequestException('No files uploaded');
    const origin = `${req.protocol}://${req.get('host')}`;
    return {
      urls: files.map((f) => `${origin}/uploads/${f.filename}`),
    };
  }
}
