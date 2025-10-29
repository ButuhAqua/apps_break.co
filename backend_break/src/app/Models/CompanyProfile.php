<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class CompanyProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'company_history',
        'vision',
        'mission',
        'quality_policy',
    ];
}
