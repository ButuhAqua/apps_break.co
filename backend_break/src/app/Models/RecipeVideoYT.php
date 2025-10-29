<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RecipeVideoYT extends Model
{
    protected $fillable = [
        'link_youtube',
        'title_h3',
        'caption_span',
    ];
}
