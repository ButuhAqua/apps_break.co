<?php

namespace App\Filament\Admin\Resources\RawMaterialInventoryBatchResource\Pages;

use App\Filament\Admin\Resources\RawMaterialInventoryBatchResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewRawMaterialInventoryBatch extends ViewRecord
{
    protected static string $resource = RawMaterialInventoryBatchResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}