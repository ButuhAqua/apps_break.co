<?php

namespace App\Filament\Admin\Resources\RawMaterialRequestResource\Pages;

use App\Filament\Admin\Resources\RawMaterialRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewRawMaterialRequest extends ViewRecord
{
    protected static string $resource = RawMaterialRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
