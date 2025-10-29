<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PressRelease extends Model
{
    use HasFactory;

    protected $fillable = [
        'big_title',
        'small_title',
        'description',
        'file_path',
        'download_title',
        'image_path',
    ];
}
