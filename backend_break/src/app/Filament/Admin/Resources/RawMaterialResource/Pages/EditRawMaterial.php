<?php

namespace App\Filament\Admin\Resources\RawMaterialResource\Pages;

use App\Filament\Admin\Resources\RawMaterialResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditRawMaterial extends EditRecord
{
    protected static string $resource = RawMaterialResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
