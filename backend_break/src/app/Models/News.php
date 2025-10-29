<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class News extends Model
{
    use HasFactory;

    protected $fillable = [
        'event_year',
        'event_name',
        'event_schedule',
        'ig_text',
        'ig_link',
        'regis_text',
        'regis_link',
        'rr_text',
        'rr_link',
        'recipe_text',
        'recipe_link',
        'download_text',
        'download_link',
        'cover_image',
    ];
}
