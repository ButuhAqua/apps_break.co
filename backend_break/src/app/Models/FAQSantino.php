<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FAQSantino extends Model
{
    use HasFactory;

    protected $table = 'f_a_q_santinos';

    protected $fillable = [
        'question',
        'answer',
    ];
}
