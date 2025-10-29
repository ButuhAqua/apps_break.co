<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FAQMilklab extends Model
{
    use HasFactory;

    protected $table = 'f_a_q_milklabs';

    protected $fillable = [
        'question',
        'answer',
    ];
}
