<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Office extends Model
{
    use HasFactory;

    protected $fillable = [
        'komitmen_mutu',
        'image_office1',
        'name_office1',
        'location_office1',
        'address_office1',
        'tel_office1',
        'fax_office1',
        'link_ig_office1',
        'link_fb_office1',
        'link_yt_office1',
        'link_wa_office1',
        'image_logo_iso',
        'image_office2',
        'name_office2',
        'location_office2',
        'address_office2',
        'tel_office2',
        'fax_office2',
        'link_ig_office2',
        'link_fb_office2',
        'link_yt_office2',
        'link_wa_office2',
    ];
}
