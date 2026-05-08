<?php

namespace App\Filament\Admin\Resources\RawMaterialInventoryResource\Pages;

use App\Filament\Admin\Resources\RawMaterialInventoryResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditRawMaterialInventory extends EditRecord
{
    protected static string $resource = RawMaterialInventoryResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
