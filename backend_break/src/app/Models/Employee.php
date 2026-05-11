<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Employee extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'employee_code',
        'full_name',
        'role',
        'assigned_location',
        'status',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}