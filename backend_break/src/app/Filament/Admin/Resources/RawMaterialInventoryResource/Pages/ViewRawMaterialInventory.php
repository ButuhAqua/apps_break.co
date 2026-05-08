<?php

namespace App\Filament\Admin\Resources\RawMaterialInventoryResource\Pages;

use App\Filament\Admin\Resources\RawMaterialInventoryResource;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class ViewRawMaterialInventory extends ViewRecord
{
    protected static string $resource = RawMaterialInventoryResource::class;

    public function infolist(Infolist $infolist): Infolist
    {
        $record = $this->record;

        return $infolist
            ->schema([
                Infolists\Components\Section::make('Informasi Inventory')
                    ->schema([
                        Infolists\Components\TextEntry::make('name')
                            ->label('Nama Bahan'),

                        Infolists\Components\TextEntry::make('category')
                            ->label('Kategori'),

                        Infolists\Components\TextEntry::make('uom')
                            ->label('Satuan'),

                        Infolists\Components\TextEntry::make('total_stock')
                            ->label('Total Stock')
                            ->state(
                                $record->inventoryBatches()
                                    ->where('qty_remaining', '>', 0)
                                    ->sum('qty_remaining')
                            ),

                        Infolists\Components\TextEntry::make('batch_count')
                            ->label('Jumlah Batch')
                            ->state(
                                $record->inventoryBatches()
                                    ->where('qty_remaining', '>', 0)
                                    ->count()
                            ),
                    ])
                    ->columns(2),

                Infolists\Components\Section::make('Daftar Batch')
                    ->schema([
                        Infolists\Components\RepeatableEntry::make('inventoryBatches')
                            ->label('')
                            ->schema([
                                Infolists\Components\TextEntry::make('batch_number')
                                    ->label('Batch'),

                                Infolists\Components\TextEntry::make('qty_remaining')
                                    ->label('Qty Tersisa'),

                                Infolists\Components\TextEntry::make('uom')
                                    ->label('Satuan'),

                                Infolists\Components\TextEntry::make('expired_date')
                                    ->label('Expired')
                                    ->date('d M Y'),

                                Infolists\Components\TextEntry::make('supplier')
                                    ->label('Supplier'),
                            ])
                            ->columns(5),
                    ]),
            ]);
    }
}