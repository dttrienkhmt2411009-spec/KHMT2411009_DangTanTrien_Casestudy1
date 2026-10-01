package com.example.dttrienkhmt2411009

import android.app.DatePickerDialog
import android.graphics.Color
import android.os.Bundle
import android.widget.ArrayAdapter
import android.widget.AutoCompleteTextView
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.button.MaterialButton
import com.google.android.material.button.MaterialButtonToggleGroup
import com.google.android.material.textfield.TextInputEditText
import java.util.Calendar

class TransactionActivity : AppCompatActivity() {

    private var isEditMode = false // Biến xác định đang là màn hình Thêm hay Sửa

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_transaction)

        val tvHeaderTitle = findViewById<TextView>(R.id.tv_header_title)
        val btnBack = findViewById<ImageView>(R.id.btn_back)
        val toggleType = findViewById<MaterialButtonToggleGroup>(R.id.toggle_type)
        val btnExpense = findViewById<MaterialButton>(R.id.btn_expense)
        val btnIncome = findViewById<MaterialButton>(R.id.btn_income)
        val edtCategory = findViewById<AutoCompleteTextView>(R.id.edt_category)
        val edtDate = findViewById<TextInputEditText>(R.id.edt_date)
        val edtAmount = findViewById<TextInputEditText>(R.id.edt_amount)
        val edtNote = findViewById<TextInputEditText>(R.id.edt_note)
        val btnSave = findViewById<MaterialButton>(R.id.btn_save)

        // 1. Kiểm tra trạng thái Thêm hay Sửa từ Intent
        isEditMode = intent.getBooleanExtra("IS_EDIT_MODE", false)

        if (isEditMode) {
            tvHeaderTitle.text = "Sửa giao dịch"
            // Giả lập điền dữ liệu cũ vào form nếu đang ở chế độ Sửa
            edtAmount.setText("100000")
            edtNote.setText("Ăn trưa")
        } else {
            tvHeaderTitle.text = "Thêm giao dịch"
        }

        // 2. Nút Quay lại
        btnBack.setOnClickListener { finish() }

        // 3. Xử lý đổi màu Nút Chi tiêu / Thu nhập khi click
        toggleType.addOnButtonCheckedListener { group, checkedId, isChecked ->
            if (isChecked) {
                if (checkedId == R.id.btn_expense) {
                    btnExpense.setBackgroundColor(Color.parseColor("#FF4C5E")) // Đỏ
                    btnExpense.setTextColor(Color.WHITE)
                    btnIncome.setBackgroundColor(Color.TRANSPARENT)
                    btnIncome.setTextColor(Color.parseColor("#757575"))
                } else {
                    btnIncome.setBackgroundColor(Color.parseColor("#4CAF50")) // Xanh lá
                    btnIncome.setTextColor(Color.WHITE)
                    btnExpense.setBackgroundColor(Color.TRANSPARENT)
                    btnExpense.setTextColor(Color.parseColor("#757575"))
                }
            }
        }
        // Kích hoạt màu mặc định lúc mới mở
        btnExpense.isChecked = true

        // 4. Cài đặt dữ liệu cho Dropdown Danh mục
        val categories = arrayOf("Ăn uống", "Di chuyển", "Mua sắm", "Tiền lương", "Khác")
        val adapter = ArrayAdapter(this, android.R.layout.simple_dropdown_item_1line, categories)
        edtCategory.setAdapter(adapter)

        // 5. Mở lịch khi click vào Ngày giao dịch
        edtDate.setOnClickListener {
            val calendar = Calendar.getInstance()
            val year = calendar.get(Calendar.YEAR)
            val month = calendar.get(Calendar.MONTH)
            val day = calendar.get(Calendar.DAY_OF_MONTH)

            val datePickerDialog = DatePickerDialog(this, { _, selectedYear, selectedMonth, selectedDay ->
                // Định dạng ngày hiển thị (VD: 12/04/2025)
                val formattedDate = String.format("%02d/%02d/%d", selectedDay, selectedMonth + 1, selectedYear)
                edtDate.setText(formattedDate)
            }, year, month, day)

            datePickerDialog.show()
        }

        // 6. Nút Lưu
        btnSave.setOnClickListener {
            val amount = edtAmount.text.toString()
            if (amount.isEmpty()) {
                Toast.makeText(this, "Vui lòng nhập số tiền", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            // Xử lý lưu database ở đây...
            Toast.makeText(this, "Lưu thành công!", Toast.LENGTH_SHORT).show()
            finish() // Đóng màn hình
        }
    }
}