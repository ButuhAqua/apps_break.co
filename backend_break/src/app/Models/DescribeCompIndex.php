<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DescribeCompIndex extends Model
{
    use HasFactory;

    protected $fillable = [
        'image',
        'title_h3',
        'subtitle_h4',
        'description_p',
        'link_ig',
        'link_fb',
        'link_yt',
        'link_wa',
    ];
}
