<?php

namespace App\Filament\Admin\Resources\RunnerTripReportResource\Pages;

use App\Filament\Admin\Resources\RunnerTripReportResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListRunnerTripReports extends ListRecords
{
    protected static string $resource = RunnerTripReportResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
