<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FAQJTC extends Model
{
    use HasFactory;

    protected $table = 'f_a_q_j_t_c_s';

    protected $fillable = [
        'question',
        'answer',
    ];
}
