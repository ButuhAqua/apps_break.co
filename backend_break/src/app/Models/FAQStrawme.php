<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FAQStrawme extends Model
{
    use HasFactory;

    protected $table = 'f_a_q_strawmes';

    protected $fillable = [
        'question',
        'answer',
    ];
}
