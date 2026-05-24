<?php

namespace App\Filament\Admin\Resources\ProductInventoryBatchResource\Pages;

use App\Filament\Admin\Resources\ProductInventoryBatchResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditProductInventoryBatch extends EditRecord
{
    protected static string $resource = ProductInventoryBatchResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
