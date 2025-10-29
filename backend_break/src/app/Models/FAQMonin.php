<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FAQMonin extends Model
{
    use HasFactory;

    protected $table = 'f_a_q_monins';

    protected $fillable = [
        'question',
        'answer',
    ];
}
