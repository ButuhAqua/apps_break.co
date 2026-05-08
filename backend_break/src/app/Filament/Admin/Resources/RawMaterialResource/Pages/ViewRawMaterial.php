<?php

namespace App\Filament\Admin\Resources\RawMaterialResource\Pages;

use App\Filament\Admin\Resources\RawMaterialResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewRawMaterial extends ViewRecord
{
    protected static string $resource = RawMaterialResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}