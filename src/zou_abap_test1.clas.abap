CLASS zou_abap_test1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    TYPES: BEGIN OF ty_item,
             id     TYPE i,
             price  TYPE p LENGTH 10 DECIMALS 2,
             amount TYPE i,
           END OF ty_item.
    TYPES tt_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    METHODS calculate_total
      IMPORTING it_items      TYPE tt_items
      RETURNING VALUE(rv_sum) TYPE ty_item-price .

    METHODS get_item_info
      IMPORTING it_items      TYPE tt_items
                iv_id         TYPE i
      RETURNING VALUE(rv_info) TYPE string.

ENDCLASS.

CLASS zou_abap_test1 IMPLEMENTATION.

  METHOD calculate_total.
    " REDUCE ile tüm satırları dönüp toplamı hesaplar
    rv_sum = REDUCE #( INIT total = 0
                       FOR wa IN it_items
                       NEXT total = total + ( wa-price * wa-amount ) ).
  ENDMETHOD.

  METHOD get_item_info.
    TRY.
        " Table Expression kullanımı
        DATA(ls_item) = it_items[ id = iv_id ].
        rv_info = |Ürün ID: { ls_item-id } - Satır Tutarı: { ls_item-price * ls_item-amount }|.
      CATCH cx_sy_itab_line_not_found.
        rv_info = |ID'si { iv_id } olan ürün bulunamadı!|.
    ENDTRY.
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    " 1. Test verilerini VALUE operatörü ile oluşturalim
    DATA(lt_my_items) = VALUE tt_items(
        ( id = 1 price = '10.50' amount = 2 )
        ( id = 2 price = '20.00' amount = 5 )
        ( id = 3 price = '100.00' amount = 1 )
    ).

    out->write( '--- Modern ABAP Test Başladı ---' ).

    " 2. Kendi metodumuzu çağıralım (Calculate Total)
    DATA(lv_grand_total) = me->calculate_total( lt_my_items ).
    out->write( |Toplam Genel Tutar: { lv_grand_total }| ).

    " 3. Tekil veri okuma (Get Item Info)
    out->write( me->get_item_info( it_items = lt_my_items iv_id = 2 ) ).

    " Hatalı ID denemesi
    out->write( me->get_item_info( it_items = lt_my_items iv_id = 99 ) ).

    " 4. MARA örneği (Eğer sisteminizde MARA yetkisi/tanımı varsa çalışır)
    " Not: Genelde testlerde yerel tipler tercih edilir.
    TYPES: BEGIN OF ty_mara_temp,
             matnr TYPE c LENGTH 18,
             ersda TYPE d,
           END OF ty_mara_temp.
    TYPES: tt_mara_temp TYPE STANDARD TABLE OF ty_mara_temp WITH EMPTY KEY.

    DATA(lt_fake_mara) = VALUE tt_mara_temp(
        ( matnr = 'MAT001' ersda = sy-datum )
        ( matnr = 'MAT002' ersda = sy-datum - 1 )
    ).

    DATA(ls_first) = VALUE #( lt_fake_mara[ 1 ] OPTIONAL ).
    out->write( |Tablo denemesi (İlk Malzeme): { ls_first-matnr }| ).

    out->write( '--- Süreç Tamamlandı ---' ).
  ENDMETHOD.

ENDCLASS.
