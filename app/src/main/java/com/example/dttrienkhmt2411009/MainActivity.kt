package com.example.dttrienkhmt2411009

import android.content.Intent
import android.os.Bundle
import android.widget.PopupMenu
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.floatingactionbutton.FloatingActionButton

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_dashboard) // Đảm bảo đúng tên file layout trang chủ của bạn

        val fabAdd = findViewById<FloatingActionButton>(R.id.fab_add)

        // Bắt sự kiện click vào nút (+)
        fabAdd.setOnClickListener { view ->
            val popupMenu = PopupMenu(this, view)

            // Tạo 2 mục lựa chọn trong Menu
            popupMenu.menu.add(0, 1, 0, "➕ Thêm giao dịch")
            popupMenu.menu.add(0, 2, 1, "✏️ Sửa giao dịch")

            // Xử lý sự kiện khi bấm chọn
            popupMenu.setOnMenuItemClickListener { item ->
                when (item.itemId) {
                    1 -> {
                        // Mở màn hình Thêm giao dịch
                        val intent = Intent(this, TransactionActivity::class.java)
                        intent.putExtra("IS_EDIT_MODE", false)
                        startActivity(intent)
                        true
                    }
                    2 -> {
                        // Mở màn hình Sửa giao dịch
                        val intent = Intent(this, TransactionActivity::class.java)
                        intent.putExtra("IS_EDIT_MODE", true)
                        startActivity(intent)
                        true
                    }
                    else -> false
                }
            }

            // Hiển thị Popup Menu
            popupMenu.show()
        }
    }
}