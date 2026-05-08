<?php

namespace App\Filament\Admin\Resources\ProductStockMovementResource\Pages;

use App\Filament\Admin\Resources\ProductStockMovementResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListProductStockMovements extends ListRecords
{
    protected static string $resource = ProductStockMovementResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
