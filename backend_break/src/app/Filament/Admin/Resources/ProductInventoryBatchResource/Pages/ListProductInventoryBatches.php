<?php

namespace App\Filament\Admin\Resources\ProductInventoryBatchResource\Pages;

use App\Filament\Admin\Resources\ProductInventoryBatchResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListProductInventoryBatches extends ListRecords
{
    protected static string $resource = ProductInventoryBatchResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
