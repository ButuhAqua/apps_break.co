<?php

namespace App\Filament\Admin\Resources\RawMaterialInventoryBatchResource\Pages;

use App\Filament\Admin\Resources\RawMaterialInventoryBatchResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditRawMaterialInventoryBatch extends EditRecord
{
    protected static string $resource = RawMaterialInventoryBatchResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
