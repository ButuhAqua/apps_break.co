<?php

namespace App\Filament\Admin\Resources\RawMaterialRequestResource\Pages;

use App\Filament\Admin\Resources\RawMaterialRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditRawMaterialRequest extends EditRecord
{
    protected static string $resource = RawMaterialRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
