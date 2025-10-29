<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NewsIndex extends Model
{
    protected $fillable = [
        'image',
        'title_h3',
        'caption_span',
    ];
}
