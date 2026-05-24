<?php

namespace App\Filament\Admin\Resources\RawMaterialInventoryBatchResource\Pages;

use App\Filament\Admin\Resources\RawMaterialInventoryBatchResource;
use Filament\Actions;
use Filament\Infolists;
use Filament\Infolists\Infolist;
use Filament\Resources\Pages\ViewRecord;

class ViewRawMaterialInventoryBatch extends ViewRecord
{
    protected static string $resource =
        RawMaterialInventoryBatchResource::class;

    protected function getHeaderActions(): array
    {
        return [

            Actions\EditAction::make(),

        ];
    }

    public function infolist(
        Infolist $infolist
    ): Infolist {

        return $infolist
            ->schema([

                Infolists\Components\Section::make(
                    'Informasi Batch Bahan Baku'
                )
                    ->schema([

                        Infolists\Components\TextEntry::make(
                            'rawMaterial.name'
                        )
                            ->label('Bahan Baku'),

                        Infolists\Components\TextEntry::make(
                            'batch_number'
                        )
                            ->label('Nomor Batch')
                            ->badge()
                            ->color('primary'),

                        Infolists\Components\TextEntry::make(
                            'supplier'
                        )
                            ->label('Supplier')
                            ->badge(),

                        Infolists\Components\TextEntry::make(
                            'uom'
                        )
                            ->label('Satuan')
                            ->badge(),

                        Infolists\Components\TextEntry::make(
                            'received_date'
                        )
                            ->label(
                                'Tanggal Masuk'
                            )
                            ->date('d M Y'),

                        Infolists\Components\TextEntry::make(
                            'expired_date'
                        )
                            ->label(
                                'Tanggal Expired'
                            )
                            ->date('d M Y'),

                        Infolists\Components\TextEntry::make(
                            'qty_in'
                        )
                            ->label('Qty Masuk')
                            ->badge()
                            ->color('success'),

                        Infolists\Components\TextEntry::make(
                            'qty_remaining'
                        )
                            ->label(
                                'Qty Tersisa'
                            )
                            ->badge()
                            ->color(function (
                                $record
                            ) {

                                if (
                                    $record->qty_remaining <= 0
                                ) {
                                    return 'gray';
                                }

                                return 'primary';
                            }),

                        Infolists\Components\TextEntry::make(
                            'status'
                        )
                            ->label('Status')
                            ->badge()
                            ->getStateUsing(function (
                                $record
                            ) {

                                if (
                                    $record->qty_remaining <= 0
                                ) {
                                    return 'Habis';
                                }

                                if (
                                    $record->expired_date &&
                                    $record->expired_date->isPast()
                                ) {
                                    return 'Expired';
                                }

                                if (
                                    $record->expired_date &&
                                    now()->lte(
                                        $record->expired_date
                                    ) &&
                                    now()->diffInDays(
                                        $record->expired_date
                                    ) <= 7
                                ) {
                                    return 'Hampir Expired';
                                }

                                return 'Aman';
                            })
                            ->color(fn (
                                string $state
                            ): string => match ($state) {

                                'Habis' => 'gray',
                                'Expired' => 'danger',
                                'Hampir Expired' => 'warning',
                                'Aman' => 'success',

                                default => 'gray',
                            }),

                        Infolists\Components\TextEntry::make(
                            'sisa_hari'
                        )
                            ->label(
                                'Sisa Waktu Expired'
                            )
                            ->badge()
                            ->color(function ($record) {
                            
                                if (
                                    $record->expired_date &&
                                    $record->expired_date->isPast()
                                ) {
                                    return 'danger';
                                }
                            
                                if (
                                    now()->diffInDays(
                                        $record->expired_date
                                    ) <= 7
                                ) {
                                    return 'warning';
                                }
                            
                                return 'success';
                            })
                            ->getStateUsing(function (
                                $record
                            ) {
                            
                                if (
                                    !$record->expired_date
                                ) {
                                    return '-';
                                }
                            
                                $getDiff = now()->diff(
                                    $record->expired_date
                                );
                            
                                if (
                                    $record->expired_date->isPast()
                                ) {
                            
                                    return 'Expired ' .
                            
                                        abs($getDiff->days) .
                                        ' hari ' .
                            
                                        $getDiff->h .
                                        ' jam lalu';
                                }
                            
                                return
                                    $getDiff->days .
                                    ' hari ' .
                            
                                    $getDiff->h .
                                    ' jam ' .
                            
                                    $getDiff->i .
                                    ' menit';
                            }),

                        Infolists\Components\TextEntry::make(
                            'notes'
                        )
                            ->label('Catatan')
                            ->placeholder(
                                'Tidak ada catatan'
                            )
                            ->columnSpanFull(),

                    ])
                    ->columns(2),

                Infolists\Components\Section::make(
                    'Informasi Sistem'
                )
                    ->schema([

                        Infolists\Components\TextEntry::make(
                            'created_at'
                        )
                            ->label('Dibuat')
                            ->dateTime(
                                'd M Y H:i'
                            ),

                        Infolists\Components\TextEntry::make(
                            'updated_at'
                        )
                            ->label(
                                'Terakhir Update'
                            )
                            ->dateTime(
                                'd M Y H:i'
                            ),

                    ])
                    ->columns(2),
            ]);
    }
}