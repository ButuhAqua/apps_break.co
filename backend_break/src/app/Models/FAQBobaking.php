<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FAQBobaking extends Model
{
    use HasFactory;

    protected $table = 'f_a_q_bobakings';

    protected $fillable = [
        'question',
        'answer',
    ];
}
