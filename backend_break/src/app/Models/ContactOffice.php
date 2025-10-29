<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ContactOffice extends Model
{
    use HasFactory;

    protected $fillable = [
        'office_name', 
        'address', 
        'working_hours', 
        'office_phone',
        'retail_phone',
        'email',
        'tokped_link',
        'whatsapp_number',
    ];
}
