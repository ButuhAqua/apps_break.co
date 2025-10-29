<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class VideoLocalIndex extends Model
{
    use HasFactory;

    protected $fillable = [
        'title', 
        'video_url', 
    ];
}
