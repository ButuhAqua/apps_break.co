<?php

namespace App\Filament\Admin\Resources\RawMaterialStockMovementResource\Pages;

use App\Filament\Admin\Resources\RawMaterialStockMovementResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListRawMaterialStockMovements extends ListRecords
{
    protected static string $resource = RawMaterialStockMovementResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
