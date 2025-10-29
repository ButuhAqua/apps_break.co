<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InfoIndex extends Model
{
    use HasFactory;

    protected $fillable = [
        'link',
        'image',
        'title_h2',
        'description_span',
    ];
}
