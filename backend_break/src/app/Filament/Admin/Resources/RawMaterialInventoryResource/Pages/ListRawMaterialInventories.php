<?php

namespace App\Filament\Admin\Resources\RawMaterialInventoryResource\Pages;

use App\Filament\Admin\Resources\RawMaterialInventoryResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListRawMaterialInventories extends ListRecords
{
    protected static string $resource = RawMaterialInventoryResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
