<?php

namespace App\Filament\Admin\Resources\ProductionReportResource\Pages;

use App\Filament\Admin\Resources\ProductionReportResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditProductionReport extends EditRecord
{
    protected static string $resource = ProductionReportResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
