<?php

namespace App\Filament\Admin\Resources\RunnerTripReportResource\Pages;

use App\Filament\Admin\Resources\RunnerTripReportResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditRunnerTripReport extends EditRecord
{
    protected static string $resource = RunnerTripReportResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
