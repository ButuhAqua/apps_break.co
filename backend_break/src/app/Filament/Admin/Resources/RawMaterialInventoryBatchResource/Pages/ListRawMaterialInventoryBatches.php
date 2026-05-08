<?php

namespace App\Filament\Admin\Resources\RawMaterialInventoryBatchResource\Pages;

use App\Filament\Admin\Resources\RawMaterialInventoryBatchResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListRawMaterialInventoryBatches extends ListRecords
{
    protected static string $resource = RawMaterialInventoryBatchResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
